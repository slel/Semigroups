/*
 * Semigroups++
 *
 * This file contains classes for creating elements of a semigroup.
 *
 */

#ifndef SEMIGROUPS_ELEMENTS_H
#define SEMIGROUPS_ELEMENTS_H
//#define NDEBUG

#include "semiring.h"

#include <assert.h>
#include <functional>
#include <iostream>
#include <math.h>
#include <vector>
#include <unordered_set>

using namespace semiring;
using namespace std;

// abstract base class for elements of a semigroup

class Element {

  public: 
    virtual ~Element () {}

    bool     operator == (const Element& that) const {
      return this->equals(&that);
    };

    virtual size_t   complexity    ()                               const = 0;
    virtual size_t   degree        ()                               const = 0;
    virtual bool     equals        (const Element*)                 const = 0;
    virtual size_t   hash_value    ()                               const = 0;
    virtual Element* identity      ()                               const = 0;
    virtual Element* really_copy   (size_t = 0)                     const = 0;
    virtual void     really_delete ()                                     = 0;
    virtual void     redefine      (Element const*, Element const*)       = 0;
};

class myequal {
public:
   size_t operator()(const Element* x, const Element* y) const{
     return x->equals(y);
   }
};

namespace std {
  template<>
    struct hash<const Element* > {
    size_t operator() (const Element* x) const {
      return x->hash_value();
    }
  };
}

// template for transformations

//TODO make a PartialTransformation class which holds the common parts of
//Transformation and PartialPerm.

template <typename T>
class Transformation : public Element {

  public:
   
    Transformation (std::vector<T>* image) : _image(image) {}
   
    inline T operator [] (size_t pos) const {
      return _image->at(pos);
    }

    size_t complexity () const {
      return _image->size();
    }

    size_t degree () const {
      return _image->size();
    }
    
    bool equals (const Element* that) const {
      return *(static_cast<const Transformation<T>*>(that)->_image) == *(this->_image);
    }
    
    size_t hash_value () const {
      size_t seed = 0;
      T deg = this->degree();
      for (T i = 0; i < deg; i++) {
        seed = ((seed * deg) + this->_image->at(i));
      }
      return seed;
    }
    
    // the identity of this
    Element* identity () const {
      auto image = new std::vector<T>();
      image->reserve(this->degree());
      for (T i = 0; i < this->degree(); i++) {
        image->push_back(i);
      }
      return new Transformation<T>(image);
    }

    Element* really_copy (size_t increase_deg_by = 0) const override {
      auto out = new std::vector<T>(*_image);
      for (size_t i = _image->size(); i < _image->size() + increase_deg_by; i++) {
        out->push_back(i);
      }
      return new Transformation<T>(out);
    }

    void really_delete () {
      delete _image;
    }

    // multiply x and y into this
    void redefine (Element const* x, Element const* y) {
      assert(x->degree() == y->degree());
      assert(x->degree() == this->degree());
      auto xx = *static_cast<Transformation<T> const*>(x);
      auto yy = *static_cast<Transformation<T> const*>(y);

      for (T i = 0; i < this->degree(); i++) {
        _image->at(i) = yy[xx[i]];
      }
    }

  private:

    std::vector<T>* _image;
};

// template for partial perms

template <typename T>
class PartialPerm : public Element {

  public:

    PartialPerm (std::vector<T>* image) : _image(image) {}
    
    inline T operator [] (size_t pos) const {
      return _image->at(pos);
    }

    size_t complexity () const {
      return _image->size();
    }
    
    size_t degree () const {
      return _image->size();
    }

    bool equals (const Element* that) const {
      return *(static_cast<const PartialPerm<T>*>(that)->_image) == *(this->_image);
    }
    
    size_t hash_value () const {
      size_t seed = 0;
      T deg = this->degree();
      for (T i = 0; i < deg; i++) {
        seed = ((seed * deg) + this->_image->at(i));
      }
      return seed;
    }
    
    // the identity of this
    Element* identity () const {
      auto image = new std::vector<T>();
      image->reserve(this->degree());
      for (T i = 0; i < this->degree(); i++) {
        image->push_back(i);
      }
      return new PartialPerm<T>(image);
    }

    Element* really_copy (size_t increase_deg_by = 0) const override {
      auto out = new std::vector<T>(*_image);
      for (size_t i = 0; i < increase_deg_by; i++) {
        out->push_back(i);
      }
      return new PartialPerm<T>(out);
    }
    
    void really_delete () {
      delete _image;
    }

    // multiply x and y into this
    void redefine (Element const* x, Element const* y) {
      assert(x->degree() == y->degree());
      assert(x->degree() == this->degree());
      auto xx = *static_cast<PartialPerm<T> const*>(x);
      auto yy = *static_cast<PartialPerm<T> const*>(y);

      for (T i = 0; i < this->degree(); i++) {
        _image->at(i) = (xx[i] == UNDEFINED ? UNDEFINED : yy[xx[i]]);
      }
    }

  private:

    std::vector<T>* _image;
    T               UNDEFINED = (T) -1;
};

// boolean matrices

class BooleanMat: public Element {

  public:

    BooleanMat             (std::vector<bool>* matrix) : _matrix(matrix) {}
    bool     at            (size_t pos)                     const;

    size_t   complexity    ()                               const;
    size_t   degree        ()                               const;
    bool     equals        (const Element*)                 const;
    size_t   hash_value    ()                               const;
    Element* identity      ()                               const;
    Element* really_copy   (size_t = 0)                     const;
    void     really_delete ();
    void     redefine      (Element const*, Element const*);
  
  private:
    

    std::vector<bool>* _matrix;

};

// bipartitions

class Bipartition : public Element {

  public:

    Bipartition            (std::vector<u_int32_t>* blocks) : _blocks(blocks) {}
    u_int32_t block        (size_t pos)                     const;

    size_t   complexity    ()                               const;
    size_t   degree        ()                               const;
    bool     equals        (const Element*)                 const;
    size_t   hash_value    ()                               const;
    Element* identity      ()                               const;
    Element* really_copy   (size_t = 0)                     const;
    void     really_delete ()                                    ;
    void     redefine      (Element const*, Element const*)      ;
  
  private:

    u_int32_t fuseit   (std::vector<u_int32_t>const&, u_int32_t);
    u_int32_t nrblocks () const;

    std::vector<u_int32_t>* _blocks;
};

class MatrixOverSemiring: public Element {

  public:

    MatrixOverSemiring     (std::vector<long>* matrix, 
                            Semiring*          semiring) :
                           _matrix(matrix),
                           _semiring(semiring) {}

    long      at            (size_t pos)                     const;
    Semiring* semiring      ()                               const;

    size_t    complexity    ()                               const;
    size_t    degree        ()                               const;
    bool      equals        (const Element*)                 const;
    size_t    hash_value    ()                               const;
    Element*  identity      ()                               const;
    Element*  really_copy   (size_t = 0)                     const;
    void      really_delete ()                                    ;
    void      redefine      (Element const*, Element const*)      ;

  private: 

    // a function applied after redefinition 
    virtual void after () {}

    std::vector<long>* _matrix;
    Semiring*          _semiring;
    
}; 

/*class ProjectiveMaxPlusMatrix: public MatrixOverSemiring {

  public:

    ProjectiveMaxPlusMatrix (size_t degree, Semiring* semiring) 
      : MatrixOverSemiring(degree, semiring) {}
    
    ProjectiveMaxPlusMatrix (size_t degree, Element* sample) 
      : MatrixOverSemiring(degree, sample) {}

  private:

    void after () {
      long norm = LONG_MIN;
      size_t deg = sqrt(this->degree());

      for (size_t i = 0; i < deg; i++) {
        for (size_t j = 0; j < deg; j++) {
          if ((long) this->at(i * deg + j) > norm)  {
            norm = this->at(i * deg + j);
          }
        }
      }
      for (size_t i = 0; i < deg; i++) {
        for (size_t j = 0; j < deg; j++) {
          if (this->at(i * deg + j) != LONG_MIN) {
            this->set(i * deg + j, this->at(i * deg + j) - norm);
          }
        }
      }
    }
};

namespace std {
  template <>
    struct hash<const ProjectiveMaxPlusMatrix> {
    size_t operator() (const ProjectiveMaxPlusMatrix& x) const {
      size_t seed = 0;
      for (size_t i = 0; i < x.degree(); i++) {
        seed = ((seed << 4) + x.at(i));
      }
      return seed;
    }
  };
}

// partitioned binary relations

class PBR: public Element<std::vector<u_int32_t> > {
  
  public:
  
    PBR (u_int32_t degree, 
         Element<std::vector<u_int32_t> >* sample = nullptr) 
      : Element<std::vector<u_int32_t> >() {
        _data = new std::vector<std::vector<u_int32_t> >();
        _data->reserve(degree);
        for (size_t i = 0; i < degree; i++) {
          _data->push_back(std::vector<u_int32_t>());
        }
      }
    
    PBR (std::vector<std::vector<u_int32_t> >
                               const& data)
      : Element<std::vector<u_int32_t> >(data) { }
    
    //FIXME this allocates lots of memory on every call, maybe better to keep
    //the data in the class and overwrite it.
    //FIXME also we repeatedly search in the same part of the graph, and so
    //there is probably a lot of repeated work in the dfs.
    void redefine (Element<std::vector<u_int32_t> > const* x, 
                   Element<std::vector<u_int32_t> > const* y) {
      assert(x->degree() == y->degree());
      assert(x->degree() == this->degree());
      u_int32_t n = this->degree() / 2;
      
      for (size_t i = 0; i < 2 * n; i++) {
        (*_data)[i].clear();
      }

      std::vector<bool> x_seen;
      std::vector<bool> y_seen;
      
      for (size_t i = 0; i < 2 * n; i++) {
        x_seen.push_back(false);
        y_seen.push_back(false);
      }
      
      for (size_t i = 0; i < n; i++) {
        x_dfs(n, i, i, x_seen, y_seen, x, y);
        for (size_t j = 0; j < 2 * n; j++) {
          x_seen.at(j) = false;
          y_seen.at(j) = false;
        }
      }
      
      for (size_t i = n; i < 2 * n; i++) {
        y_dfs(n, i, i, x_seen, y_seen, x, y);
        for (size_t j = 0; j < 2 * n; j++) {
          x_seen.at(j) = false;
          y_seen.at(j) = false;
        }
      }
    }
    
    Element<std::vector<u_int32_t> >* identity () {
      std::vector<std::vector<u_int32_t> > adj;
      size_t n = this->degree() / 2;
      adj.reserve(2 * n);
      for (u_int32_t i = 0; i < 2 * n; i++) {
        adj.push_back(std::vector<u_int32_t>());
      }
      for (u_int32_t i = 0; i < n; i++) {
        adj.at(i).push_back(i + n);
        adj.at(i + n).push_back(i);
      }
      return new PBR(adj);
    }
    
    size_t complexity () const {
      return pow((2 * this->degree()), 3);
    }

  private:

    // add vertex2 to the adjacency of vertex1
    void add_adjacency (size_t vertex1, size_t vertex2) {
      auto it = std::lower_bound(_data->at(vertex1).begin(),
                                 _data->at(vertex1).end(), 
                                 vertex2);
      if (it == _data->at(vertex1).end()) {
        _data->at(vertex1).push_back(vertex2);
      } else if ((*it) != vertex2) {
        _data->at(vertex1).insert(it, vertex2);
      }
    }

    void x_dfs (u_int32_t n,
                u_int32_t i, 
                u_int32_t v,  // the vertex we're currently doing
                std::vector<bool>& x_seen,
                std::vector<bool>& y_seen,
                Element<std::vector<u_int32_t> > const* x, 
                Element<std::vector<u_int32_t> > const* y) {

      if (!x_seen.at(i)) {
        x_seen.at(i) = true;
        for (auto j: x->at(i)) {
          if (j < n) {
            add_adjacency(v, j);
          } else {
            y_dfs(n, j - n, v, x_seen, y_seen, x, y);
          }
        }
      }
    }

    void y_dfs (u_int32_t n,
                u_int32_t i, 
                u_int32_t v, 
                std::vector<bool>& x_seen,
                std::vector<bool>& y_seen,
                Element<std::vector<u_int32_t> > const* x, 
                Element<std::vector<u_int32_t> > const* y) {

      if (!y_seen.at(i)) {
        y_seen.at(i) = true;
        for (auto j: y->at(i)) {
          if (j >= n) {
            add_adjacency(v, j);
          } else {
            x_dfs(n, j + n, v, x_seen, y_seen, x, y);
          }
        }
      }
    }
};

namespace std {
  template <>
    struct hash<const PBR> {
    size_t operator() (const PBR& x) const {
      size_t seed = 0;
      size_t pow = 101;
      for (size_t i = 0; i < x.degree(); i++) {
        for (size_t j = 0; j < x.at(i).size(); j++) { 
          seed = (seed * pow) + x.at(i).at(j);
        }
      }
      return seed;
    }
  };
}*/

#endif
